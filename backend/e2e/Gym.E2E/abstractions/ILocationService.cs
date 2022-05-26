using System.Collections.Generic;
using System.Threading.Tasks;

namespace Gym.E2E
{
    internal interface IVisitsService
    {
        public Task CreateVisit(string gymId, Coordinates coordinates);

        public Task<IEnumerable<VisitModel>> GetUserVisits();
    }
}