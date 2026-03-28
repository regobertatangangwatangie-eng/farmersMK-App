package com.farmpro.common.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DateUtils {

    private static final String DEFAULT_FORMAT = "yyyy-MM-dd HH:mm:ss";

    public static String now() {
        return LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern(DEFAULT_FORMAT));
    }
}