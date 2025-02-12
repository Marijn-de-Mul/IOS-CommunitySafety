using CommunitySafety.SAL.Models;
using System.Threading.Tasks;
using CommunitySafety.DAL;
using CommunitySafety.SAL.Interfaces;

namespace CommunitySafety.SAL.Repositories
{
    public class AlertRepository : IAlertRepository
    {
        private readonly ApplicationDbContext _context;

        public AlertRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task AddAlert(Alert alert)
        {
            _context.Alerts.Add(alert);
            await _context.SaveChangesAsync();
        }
    }
}