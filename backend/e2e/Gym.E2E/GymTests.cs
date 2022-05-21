using System;
using System.Threading.Tasks;
using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Xunit;
using Firebase.Auth;
using Microsoft.Extensions.DependencyInjection;
using System.Net.Http;
using System.Net.Http.Json;
using System.Collections.Generic;
using FluentAssertions;
using Microsoft.Extensions.Logging;

namespace Gym.E2E;

public class GymsTests : IClassFixture<GymsTests>, IAsyncLifetime
{
    private readonly IConfiguration _configuration = ConfigurationBuilder.Build();
    private readonly ILogger<GymsTests> logger = LoggerFactory.Create(b => b.AddConsole())
        .CreateLogger<GymsTests>();

    [Fact]
    public async Task CreateGymInGymsService()
    {
        logger.LogInformation("Creating gym in GymsService");
        var provider = GetProvider();

        var client = provider.GetRequiredService<IGymService>();

        var gym = new CreateGymModel()
        {
            Lat = 123.123,
            Lng = 123.123,
            Name = Guid.NewGuid().ToString(),
        };

        var expectedGym = new GymModel()
        {
            Lat = gym.Lat,
            Lng = gym.Lng,
            Name = gym.Name,
        };
        
        await client.CreateGym(gym);
        var gyms = await client.GetGyms();

        gyms.Should()
            .NotBeEmpty()
            .And
            .ContainEquivalentOf(expectedGym, cfg =>
                cfg.Excluding(g => g.UserId)
                .Excluding(g => g.CreatedDate));
    }

    public Task DisposeAsync()
    {
        return Task.CompletedTask;
    }

    public Task InitializeAsync()
    {
        var healthChecker = new HealthCheck<ILogger<GymsTests>>(_configuration, logger);

        return healthChecker.CheckHealth("GymsEndpoint");
    }

    private IServiceProvider GetProvider()
    {
        IServiceCollection collection = new ServiceCollection();
        collection.Configure<EndpointsConfig>(_configuration.GetSection("Gym"));

        collection.AddSingleton<IGymService, GymClient>();
        collection.AddSingleton<IAccessProvider, AccessProvider>();
        collection.AddHttpClient();
        collection.AddLogging();

        return collection.BuildServiceProvider();
    }
}

public interface IHealthCheck<TLogger>
    where TLogger: ILogger
{
    Task<bool> CheckHealth(string endpoint);
}

public class HealthCheck<TLogger> : IHealthCheck<TLogger>
    where TLogger: ILogger
{
    private readonly IConfiguration configuration;
    private readonly TLogger logger;

    public HealthCheck(IConfiguration configuration, TLogger logger)
    {
        this.configuration = configuration;
        this.logger = logger;
    }

    public async Task<bool> CheckHealth(string endpoint)
    {
        var address = configuration.GetSection("Gym").GetValue<string>(endpoint);

        var client = new HttpClient();

        int attempt = 0;
        while(attempt < 5)
        {
            try
            {
                var result = await client.GetAsync(address);

                if(result.IsSuccessStatusCode)
                {
                    logger.LogInformation($"{endpoint} is healthy");
                    return true;
                }

                logger.LogWarning($"{endpoint} is not healthy");
                await Task.Delay(500);
                attempt++;
            }
            catch
            {
                logger.LogWarning($"{endpoint} is not healthy");
                await Task.Delay(500);
                attempt++;
                continue;
            }
        }

        return false;
    }
}

public interface IGymService
{
    public Task CreateGym(CreateGymModel createGymModel);

    public Task<IEnumerable<GymModel>> GetGyms();
}

public class GymClient : IGymService
{
    private readonly IOptions<EndpointsConfig> options;
    private readonly IAccessProvider accessProvider;
    private readonly IHttpClientFactory clientFactory;
    private readonly ILogger<GymClient> logger;

    public GymClient(IOptions<EndpointsConfig> options, IAccessProvider accessProvider, IHttpClientFactory clientFactory, ILogger<GymClient> logger)
    {
        this.options = options;
        this.accessProvider = accessProvider;
        this.clientFactory = clientFactory;
        this.logger = logger;
    }

    public async Task CreateGym(CreateGymModel gym)
    {
        var token = await accessProvider.GetToken();
        var createGymUri = options.Value.GymsEndpoint;
        using var client = clientFactory.CreateClient();
        client.DefaultRequestHeaders.Add("Authorization", $"{token}");

        logger.LogInformation($"Creating gym {gym.Name}");
        var response = await client.PostAsJsonAsync(createGymUri, gym);

        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException($"Failed to create gym with code: {response.StatusCode}");
        }
    }

    public async Task<IEnumerable<GymModel>> GetGyms()
    {
        var token = await accessProvider.GetToken();
        var getGymUri = options.Value.GymsEndpoint;
        using var client = clientFactory.CreateClient();
        client.DefaultRequestHeaders.Add("Authorization", $"{token}");

        var response = await client.GetFromJsonAsync<IEnumerable<GymModel>>(getGymUri);

        return response;
    }
}

public class CreateGymModel
{
    public string Name { get; set; }

    public double Lat { get; set; }

    public double Lng { get; set; }
}

public class GymModel
{
    public string Name { get; set; }

    public double Lat { get; set; }

    public double Lng { get; set; }

    public DateTime CreatedDate { get; set; }

    public string UserId { get; set; }
}

public interface IAccessProvider
{
    public Task<string> GetToken();
}

public class AccessProvider : IAccessProvider
{
    private readonly IOptions<EndpointsConfig> options;

    public AccessProvider(IOptions<EndpointsConfig> options)
    {
        this.options = options;
    }

    public async Task<string> GetToken()
    {
        var defaultAuth = FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance;

        if (defaultAuth == null) 
        {
            var app = FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.GetApplicationDefault(),
            });

            defaultAuth = FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance;
        }

        if (defaultAuth == null)
        {
            throw new InvalidOperationException("Default auth not found.");
        }

        await defaultAuth.EnsureUserExists(options.Value);
        return await GetTokenInternal(options.Value);
    }

    private async Task<string> GetTokenInternal(EndpointsConfig config)
    {
        var authProvider = new FirebaseAuthProvider(new FirebaseConfig(config.FirebaseGymApiKey));

        var auth = await authProvider.SignInWithEmailAndPasswordAsync(config.UserEmail, config.UserPassword);
        return auth.FirebaseToken;
    }
}

public static class FirebaseAuthExtensions
{
    public static async Task EnsureUserExists(this FirebaseAdmin.Auth.FirebaseAuth auth, EndpointsConfig config)
    {
        try
        {
            var user = await auth.GetUserByEmailAsync(config.UserEmail);
        }
        catch (FirebaseAdmin.Auth.FirebaseAuthException ex)
        {
            await auth.CreateUserAsync(new UserRecordArgs()
            {
                Email = config.UserEmail,
                EmailVerified = true,
                Password = config.UserPassword,
                DisplayName = "Test User",
                Disabled = false,
            });
        }
    }
}

public static class ConfigurationBuilder
{
    public static IConfiguration Build()
    {
        return new Microsoft.Extensions.Configuration.ConfigurationBuilder()
            .AddJsonFile("appsettings.json")
            .AddEnvironmentVariables()
            .Build();
    }
}

public class EndpointsConfig
{
    public string GymsEndpoint { get; set; }

    public string LocationsEndpoint { get; set; }

    public string UserEmail { get; set; }

    public string UserPassword { get; set; }

    public string FirebaseGymApiKey { get; set; }
}