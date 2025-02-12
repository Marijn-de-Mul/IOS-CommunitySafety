using CommunitySafety.SAL.Models;
using Microsoft.AspNetCore.Mvc;

namespace CommunitySafety.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AlertController : ControllerBase
    {
        [HttpPost]
        public IActionResult PushAlert([FromHeader] string token, [FromBody] AlertRequest alert)
        {
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