using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace engine_api.Migrations
{
    /// <inheritdoc />
    public partial class AddTransformationsJSONToActor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "transformation",
                table: "Actors",
                type: "json",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");
            
            migrationBuilder.Sql(
            @"UPDATE `Actors`
                SET `transformation` = '{}'
                WHERE `transformation` like `null`;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "transformation",
                table: "Actors");
        }
    }
}
