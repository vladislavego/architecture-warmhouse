package com.example.temperature

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class TemperatureApplication

fun main(args: Array<String>) {
    runApplication<TemperatureApplication>(*args)
}