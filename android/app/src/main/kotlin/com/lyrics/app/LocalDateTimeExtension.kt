package com.lyrics.app

import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter

fun LocalDateTime.toIso8601String(): String {
    val iso8601Format = DateTimeFormatter.ofPattern("uuuu-MM-dd'T'HH:mm:ss.SSSX")
    return atOffset(ZoneOffset.UTC).format(iso8601Format)
}