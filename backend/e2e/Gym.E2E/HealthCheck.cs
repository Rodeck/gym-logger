using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using Microsoft.Extensions.Logging;

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
