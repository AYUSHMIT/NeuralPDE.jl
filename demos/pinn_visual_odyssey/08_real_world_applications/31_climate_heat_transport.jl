"""
# Climate Heat Transport

Model ocean heat transport for climate modeling.

**Complexity**: ⭐⭐⭐⭐ Advanced (2 hours)
"""

using Plots, Random
Random.seed!(2800)

println("Ocean Heat Transport Modeling")

# Ocean temperature field
lon = range(-180, 180, length=180)
lat = range(-90, 90, length=90)

# Temperature distribution (warmer at equator)
temp = [20 * exp(-(la/30)^2) + 10 + 
        3*sin(lo/30)*cos(la/20) for lo in lon, la in lat]

heatmap(lon, lat, temp',
        xlabel="Longitude", ylabel="Latitude",
        title="Ocean Surface Temperature (°C)",
        color=:thermal, clim=(0, 30),
        size=(1000, 500), dpi=150,
        colorbar_title="Temperature")
savefig("31_climate_heat.png")
println("✓ Saved: 31_climate_heat.png")

println("\nApplications: Climate predictions, El Niño forecasting")
