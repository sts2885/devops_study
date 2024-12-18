package com.studyhome.helloapi;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;

@RestController
public class HelloApiController {

    @GetMapping("/hello")
    public String helloGet() {
        return "Hello Get";
    }

    @PostMapping("/hello")
    public String helloPost() {
        return "Hello post";
    }

    @PutMapping("hello")
    public String helloPut() {
        return "Hello put";
    }

    @DeleteMapping("/hello")
    public String helloDelete() {
        return "Hello delete";
    }

}
