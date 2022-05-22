using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;
using System.Net.Http;
using System.Net.Http.Json;
using System.Collections.Generic;
using Microsoft.Extensions.Logging;

namespace Gym.E2E;

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
        var createGymUri = $"{options.Value.GymsEndpoint}/";
        using var client = clientFactory.CreateClient();
        client.DefaultRequestHeaders.Add("Authorization", $"{token}");

        logger.LogInformation($"Creating gym {gym.Name}");
        var response = await client.PostAsJsonAsync(createGymUri, gym);

        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException($"Failed to create gym with code: {response.StatusCode}, error: {await response.Content.ReadAsStringAsync()}");
        }
    }

    public async Task<IEnumerable<GymModel>> GetGyms()
    {
        var getGymUri = $"{options.Value.GymsEndpoint}/";

        using var client = clientFactory.CreateClient();
        await accessProvider.Authorize(client);

        var response = await client.GetFromJsonAsync<IEnumerable<GymModel>>(getGymUri);

        return response;
    }

    public async Task<IEnumerable<GymModel>> GetNearby(Coordinates coordinates)
    {
        var getGymUri = $"{options.Value.GymsEndpoint}/nearby?lat={coordinates.Lat}&lng={coordinates.Lng}";

        using var client = clientFactory.CreateClient();
        await accessProvider.Authorize(client);

        var response = await client.GetFromJsonAsync<IEnumerable<GymModel>>(getGymUri);

        return response;
    }
}

public static class HttpClientExtensions
{
    public static async Task Authorize(this IAccessProvider accessProvider, HttpClient client)
    {
        var token = await accessProvider.GetToken();
        client.DefaultRequestHeaders.Add("Authorization", $"{token}");
    }
}
