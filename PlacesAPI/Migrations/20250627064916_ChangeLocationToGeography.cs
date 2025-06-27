using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

#nullable disable

namespace PlacesAPI.Migrations
{
    /// <inheritdoc />
    public partial class ChangeLocationToGeography : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<Point>(
                name: "Location",
                table: "Places",
                type: "geography (Point, 4326)",
                nullable: false,
                oldClrType: typeof(Point),
                oldType: "geometry(Point)");

            migrationBuilder.AlterColumn<Point>(
                name: "Center",
                table: "GoogleApiQueries",
                type: "geography (Point, 4326)",
                nullable: false,
                oldClrType: typeof(Point),
                oldType: "geometry(Point)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<Point>(
                name: "Location",
                table: "Places",
                type: "geometry(Point)",
                nullable: false,
                oldClrType: typeof(Point),
                oldType: "geography (Point, 4326)");

            migrationBuilder.AlterColumn<Point>(
                name: "Center",
                table: "GoogleApiQueries",
                type: "geometry(Point)",
                nullable: false,
                oldClrType: typeof(Point),
                oldType: "geography (Point, 4326)");
        }
    }
}
