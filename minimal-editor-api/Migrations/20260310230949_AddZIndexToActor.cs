using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace engine_api.Migrations
{
    /// <inheritdoc />
    public partial class AddZIndexToActor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<float>(
                name: "Z",
                table: "Actors",
                type: "float",
                nullable: false,
                defaultValue: 0f);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Z",
                table: "Actors");
        }
    }
}
