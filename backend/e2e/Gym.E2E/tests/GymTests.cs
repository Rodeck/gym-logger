using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Xunit;
using Microsoft.Extensions.DependencyInjection;
using FluentAssertions;
using Microsoft.Extensions.Logging;

namespace Gym.E2E;

public class GymsTestsFixture: IDisposable
{
    private readonly IConfiguration _configuration = ConfigurationBuilder.Build();
    private readonly ILogger<GymsTests> logger = LoggerFactory.Create(b => b.AddConsole())
        .CreateLogger<GymsTests>();

    public GymsTestsFixture()
    {
        InitializeAsync().GetAwaiter().GetResult();
    }

    public void Dispose()
    {
    }

    public async Task InitializeAsync()
    {
        var healthChecker = new HealthCheck<ILogger<GymsTests>>(_configuration, logger);

        await healthChecker.CheckHealth("Gym");
        await healthChecker.CheckHealth("Visit");
    }
}

public class GymsTests : IClassFixture<GymsTestsFixture>
{
    private readonly IConfiguration _configuration = ConfigurationBuilder.Build();
    private readonly ILogger<GymsTests> logger = LoggerFactory.Create(b => b.AddConsole())
        .CreateLogger<GymsTests>();

    [Fact]
    public async Task CreateGymInGymsService()
    {
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
                .Excluding(g => g.CreatedDate)
                .Excluding(g => g.Id));
    }

    
    [Fact]
    public async Task GetNearbyShouldReturnGymAtTheSameLocationGym()
    {
        var provider = GetProvider();

        var client = provider.GetRequiredService<IGymService>();

        var random = new Random();

        var gym = new CreateGymModel()
        {
            Lat = random.NextDouble() * 300,
            Lng = random.NextDouble() * 300,
            Name = Guid.NewGuid().ToString(),
        };

        var expectedGym = new GymModel()
        {
            Lat = gym.Lat,
            Lng = gym.Lng,
            Name = gym.Name,
        };
        
        await client.CreateGym(gym);
        var gyms = await client.GetNearby(new Coordinates()
        {
            Lat = gym.Lat,
            Lng = gym.Lng,
        });

        gyms.Should()
            .NotBeEmpty()
            .And
            .ContainEquivalentOf(expectedGym, cfg =>
                cfg.Excluding(g => g.UserId)
                .Excluding(g => g.CreatedDate)
                .Excluding(g => g.Id));
    }

    [Fact]
    public async Task CreateGymInVisitsService()
    {
        var provider = GetProvider();

        var client = provider.GetRequiredService<IGymService>();
        var visitsClient = provider.GetRequiredService<IVisitsService>();

        var gym = new CreateGymModel()
        {
            Lat = 123.123,
            Lng = 123.123,
            Name = Guid.NewGuid().ToString(),
        };
        
        var newGym = await client.CreateGym(gym);

        // Give message queue time to process
        await Task.Delay(1000);

        // Create visit with given gym, if this succeeds, the gym was created in the visits service
        await visitsClient.CreateVisit(newGym.Id, new Coordinates()
        {
            Lat = newGym.Lat,
            Lng = newGym.Lng,
        });

        var visits = await visitsClient.GetUserVisits();

        var expectedVisit = new VisitModel()
        {
            GymId = newGym.Id,
            Lat = newGym.Lat,
            Lng = newGym.Lng,
        };

        visits.Should()
            .ContainEquivalentOf(expectedVisit, cfg => cfg.Excluding(g => g.CreatedDate).Excluding(g => g.UserId));
    }

    public Task DisposeAsync()
    {
        return Task.CompletedTask;
    }

    private IServiceProvider GetProvider()
    {
        IServiceCollection collection = new ServiceCollection();
        collection.Configure<GymsConfig>(_configuration.GetSection("Gym"));
        collection.Configure<AuthConfig>(_configuration.GetSection("Auth"));
        collection.Configure<VisitConfig>(_configuration.GetSection("Visit"));

        collection.AddTransient<IGymService, GymClient>();
        collection.AddTransient<IVisitsService, VisitClient>();
        collection.AddSingleton<IAccessProvider, AccessProvider>();
        collection.AddHttpClient();
        collection.AddLogging();

        return collection.BuildServiceProvider();
    }
}