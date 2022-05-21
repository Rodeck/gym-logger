using System.Threading.Tasks;
using System.Collections.Generic;

namespace Gym.E2E;

public interface IGymService
{
    public Task CreateGym(CreateGymModel createGymModel);

    public Task<IEnumerable<GymModel>> GetGyms();

    public Task<IEnumerable<GymModel>> GetNearby(Coordinates coordinates);
}
