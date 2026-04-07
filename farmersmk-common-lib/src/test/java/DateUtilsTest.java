package com.FarmersMK.common;

import com.FarmersMK.common.util.DateUtils;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class DateUtilsTest {

    @Test
    void testNow() {
        String now = DateUtils.now();

        assertNotNull(now);
        assertTrue(now.length() > 0);
    }
}