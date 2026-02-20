using Microsoft.EntityFrameworkCore.Migrations;
using MinimalEngineApi.Models;
using System.Collections.Generic;
using System.Drawing;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

#nullable disable

namespace engine_api.Migrations
{
    /// <inheritdoc />
    public partial class AddColorToActor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Color",
                table: "Actors",
                type: "varchar(7)",
                nullable: false,
                defaultValue: "")
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.Sql(@"
                UPDATE Actors
                SET color = CASE Type
                    WHEN 'rectangle' THEN '#e74c3c'
                    WHEN 'circle'    THEN '#3498db'
                    ELSE                  '#898222'
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Color",
                table: "Actors");
        }
    }
}
