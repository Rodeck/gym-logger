using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using Microsoft.Extensions.Logging;
using System;

namespace Gym.E2E;

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
        var address = configuration.GetSection(endpoint).GetValue<string>("Endpoint");

        var client = new HttpClient();

        int attempt = 0;
        while(attempt < 15)
        {
            try
            {
                var result = await client.GetAsync($"{address}/health");

                if(result.IsSuccessStatusCode)
                {
                    logger.LogInformation($"{endpoint} is healthy");
                    return true;
                }

                logger.LogWarning($"{endpoint} is not healthy, attempt: {attempt}, {result.StatusCode}");
                await Task.Delay(1000);
                attempt++;
            }
            catch(Exception ex)
            {
                logger.LogError(ex, $"{endpoint} is not healthy, attempt: {attempt}");
                await Task.Delay(1000);
                attempt++;
            }
        }

        throw new Exception("Health check failed.");
    }
}
