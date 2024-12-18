package com.studyhome.helloapi;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

;

@RestController
public class HelloCustomerApiController {

    @PostMapping("/hello/customer")
    public String helloPostCustomer(@RequestBody Customer customer) {
        return "Hello Post " + customer.getName();
    }

    @GetMapping("/hello/customer")
    public String hellocustomerParam(@RequestParam Long customerId) {
        return "hl post :" + customerId;
    }

    @GetMapping("/hello/customer/{customerId}")
    public String helloCustomer(@PathVariable Long customerId) {
        return "hello post " + customerId;
    }

}
