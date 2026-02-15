using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace engine_api.Migrations
{
    /// <inheritdoc />
    public partial class ChangeSceneAndActorIdsToGuid : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 1. Add temp Guid columns (nullable) to both tables
            migrationBuilder.AddColumn<Guid>(
                name: "NewId",
                table: "Scenes",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "NewId",
                table: "Actors",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "NewSceneId",
                table: "Actors",
                type: "TEXT",
                nullable: true);

            // 2. Generate new Guids for Scenes.NewId (SQLite has no built-in uuid(), so use random_blob + hex)
            // Note: This creates RFC 4122-compliant random Guids. If you prefer a lib, but SQLite is limited.
            migrationBuilder.Sql(@"
        UPDATE Scenes
        SET NewId = LOWER(
            HEX(RANDOMBLOB(4)) || '-' ||
            HEX(RANDOMBLOB(2)) || '-' ||
            HEX(RANDOMBLOB(2)) || '-' ||
            HEX(RANDOMBLOB(2)) || '-' ||
            HEX(RANDOMBLOB(6))
        )
        WHERE NewId IS NULL;
    ");

            // Generate for Actors.NewId (same way)
            migrationBuilder.Sql(@"
        UPDATE Actors
        SET NewId = LOWER(
            HEX(RANDOMBLOB(4)) || '-' ||
            HEX(RANDOMBLOB(2)) || '-' ||
            HEX(RANDOMBLOB(2)) || '-' ||
            HEX(RANDOMBLOB(2)) || '-' ||
            HEX(RANDOMBLOB(6))
        )
        WHERE NewId IS NULL;
    ");

            // 3. Remap Actors.NewSceneId to the NEW Guids from Scenes (using a join on old IDs)
            migrationBuilder.Sql(@"
        UPDATE Actors
        SET NewSceneId = (
            SELECT NewId FROM Scenes WHERE Scenes.Id = Actors.SceneId
        )
        WHERE SceneId IS NOT NULL;
    ");

            // 4. Drop FK (adjust name if yours is different — check your DB or previous migrations)
            migrationBuilder.DropForeignKey(
                name: "FK_Actors_Scenes_SceneId",  // Common default name
                table: "Actors");

            // 5. Drop PKs
            migrationBuilder.DropPrimaryKey(
                name: "PK_Scenes",
                table: "Scenes");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Actors",
                table: "Actors");

            // 6. Drop old int columns (now that data is safe in new cols)
            migrationBuilder.DropColumn(
                name: "Id",
                table: "Scenes");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "Actors");

            migrationBuilder.DropColumn(
                name: "SceneId",
                table: "Actors");

            // 7. Rename new cols to the original names
            migrationBuilder.RenameColumn(
                name: "NewId",
                table: "Scenes",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "NewId",
                table: "Actors",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "NewSceneId",
                table: "Actors",
                newName: "SceneId");

            // 8. Make them non-nullable
            migrationBuilder.AlterColumn<Guid>(
                name: "Id",
                table: "Scenes",
                type: "TEXT",
                nullable: false,
                oldClrType: typeof(Guid),
                oldNullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "Id",
                table: "Actors",
                type: "TEXT",
                nullable: false,
                oldClrType: typeof(Guid),
                oldNullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "SceneId",
                table: "Actors",
                type: "TEXT",
                nullable: false,  // Assuming it's required; set to true if nullable
                oldClrType: typeof(Guid),
                oldNullable: true);

            // 9. Recreate PKs (no autoincrement needed for Guid)
            migrationBuilder.AddPrimaryKey(
                name: "PK_Scenes",
                table: "Scenes",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Actors",
                table: "Actors",
                column: "Id");

            // 10. Recreate FK
            migrationBuilder.AddForeignKey(
                name: "FK_Actors_Scenes_SceneId",
                table: "Actors",
                column: "SceneId",
                principalTable: "Scenes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);  // Or Restrict/NoAction — match your model
        }
    }
}
