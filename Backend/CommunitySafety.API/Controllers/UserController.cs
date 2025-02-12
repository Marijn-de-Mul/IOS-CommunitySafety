using CommunitySafety.SAL.Models;
using Microsoft.AspNetCore.Mvc;

namespace CommunitySafety.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest loginRequest)
        {
            return Ok();
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterRequest registerRequest)
        {
            return Ok();
        }

        [HttpGet("account")]
        public IActionResult GetAccountInfo([FromHeader] string token)
        {
            return Ok();
        }
    }
}