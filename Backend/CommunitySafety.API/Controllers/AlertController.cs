using CommunitySafety.SAL.Models;
using CommunitySafety.SAL.Services;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using CommunitySafety.SAL.Services.Interfaces;

namespace CommunitySafety.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AlertController : ControllerBase
    {
        private readonly IAlertService _alertService;

        public AlertController(IAlertService alertService)
        {
            _alertService = alertService;
        }

        [HttpPost]
        public async Task<IActionResult> PushAlert([FromHeader] string token, [FromBody] AlertRequest alert)
        {
            await _alertService.SendAlert(alert);
            return Ok();
        }

        [HttpGet]
        public IActionResult GetAlerts([FromQuery] double latitude, [FromQuery] double longitude)
        {
            return Ok();
        }

        [HttpDelete("{id}")]
        public IActionResult DeleteAlert(int id)
        {
            return Ok();
        }

        [HttpPost("{id}")]
        public IActionResult EditAlert(int id, [FromBody] AlertRequest alert)
        {
            return Ok();
        }
    }
}