package com.example.temperature.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.PathVariable
import kotlin.random.Random

data class TemperatureResponse(
    val location: String,
    val value: Double,
    val unit: String = "°C",
    val status: String = "active"
)

@RestController
class TemperatureController {

    @GetMapping("/temperature")
    fun getTemperature(@RequestParam location: String): TemperatureResponse {
        return TemperatureResponse(location, "%.1f".format(getRandomTemperature()).toDouble())
    }

    @GetMapping("/temperature/{id}")
    fun getTemperatureById(@PathVariable id: String): TemperatureResponse {
        // для простоты — можно подставлять фиктивное имя location
        return TemperatureResponse(location = "sensor-$id", "%.1f".format(getRandomTemperature()).toDouble())
    }

    private fun getRandomTemperature(): Double {
        return Random.nextDouble(-10.0, 35.0)
    }
}