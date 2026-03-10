using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace engine_api.Migrations
{
    /// <inheritdoc />
    public partial class AddActorTypeAndActorUrlToActor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Type",
                table: "Actors",
                newName: "type");

            migrationBuilder.AlterColumn<string>(
                name: "type",
                table: "Actors",
                type: "varchar(20)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "longtext")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AlterColumn<string>(
                name: "Color",
                table: "Actors",
                type: "varchar(7)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(7)")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "ActorUrl",
                table: "Actors",
                type: "longtext",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ActorUrl",
                table: "Actors");

            migrationBuilder.RenameColumn(
                name: "type",
                table: "Actors",
                newName: "Type");

            migrationBuilder.AlterColumn<string>(
                name: "Type",
                table: "Actors",
                type: "longtext",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "varchar(20)")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "Actors",
                keyColumn: "Color",
                keyValue: null,
                column: "Color",
                value: "");

            migrationBuilder.AlterColumn<string>(
                name: "Color",
                table: "Actors",
                type: "varchar(7)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "varchar(7)",
                oldNullable: true)
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }
    }
}
