using CommunitySafety.SAL.Models;
using System.Threading.Tasks;
using CommunitySafety.SAL.Interfaces;
using CommunitySafety.SAL.Services.Interfaces;

namespace CommunitySafety.SAL.Services
{
    public class AlertService : IAlertService 
    {
        private readonly IAlertRepository _repository;

        public AlertService(IAlertRepository repository)
        {
            _repository = repository;
        }

        public async Task SendAlert(AlertRequest request)
        {
            var alert = new Alert
            {
                Title = request.Title,
                Description = request.Description,
                Severity = request.Severity,
                Type = request.Type,
                Location = request.Location
            };

            await _repository.AddAlert(alert);
        }
    }
}