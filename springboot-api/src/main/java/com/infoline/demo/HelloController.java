package com.infoline.demo;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*")
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello World from Spring Boot!";
    }
}
