using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace Gym.E2E;

public interface IHealthCheck<TLogger>
    where TLogger: ILogger
{
    Task<bool> CheckHealth(string endpoint);
}
