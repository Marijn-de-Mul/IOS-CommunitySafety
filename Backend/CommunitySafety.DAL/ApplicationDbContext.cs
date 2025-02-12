using Microsoft.EntityFrameworkCore;
using CommunitySafety.SAL.Models;

namespace CommunitySafety.DAL
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<Alert> Alerts { get; set; }
        public DbSet<User> Users { get; set; }
    }
}