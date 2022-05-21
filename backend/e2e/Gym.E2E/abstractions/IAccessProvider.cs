using System.Threading.Tasks;

namespace Gym.E2E;

public interface IAccessProvider
{
    public Task<string> GetToken();
}
