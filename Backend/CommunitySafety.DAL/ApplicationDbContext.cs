using Microsoft.EntityFrameworkCore;
using CommunitySafety.SAL.Models;

namespace CommunitySafety.DAL
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<Alert> Alerts { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<OTPRequest> OTPRequests { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Alert>()
                .OwnsOne(a => a.Location);
            base.OnModelCreating(modelBuilder);
        }
    }
}