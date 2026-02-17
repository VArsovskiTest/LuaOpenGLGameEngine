using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace engine_api.Migrations
{
    /// <inheritdoc />
    public partial class AddSceneIdToActors_Nullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<Guid>(
                name: "SceneId",
                table: "Actors",
                type: "binary(16)",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "binary(16)");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Actors",
                type: "datetime(6)",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "Actors",
                type: "datetime(6)",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Actors");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "Actors");

            migrationBuilder.AlterColumn<Guid>(
                name: "SceneId",
                table: "Actors",
                type: "binary(16)",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "binary(16)",
                oldNullable: true);
        }
    }
}
