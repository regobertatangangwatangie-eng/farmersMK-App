package com.farmpro.common;

import com.farmpro.common.response.ApiResponse;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class ApiResponseTest {

    @Test
    void testSuccessResponse() {
        ApiResponse<String> response = ApiResponse.success("data");

        assertTrue(response.isSuccess());
        assertEquals("Success", response.getMessage());
        assertEquals("data", response.getData());
    }

    @Test
    void testErrorResponse() {
        ApiResponse<?> response = ApiResponse.error("error");

        assertFalse(response.isSuccess());
        assertEquals("error", response.getMessage());
        assertNull(response.getData());
    }
}