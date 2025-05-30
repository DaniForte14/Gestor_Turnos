package com.gestorhorarios;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import javax.sql.DataSource;

@SpringBootApplication
public class GestorHorariosApplication {
    public static void main(String[] args) {
        SpringApplication.run(GestorHorariosApplication.class, args);
    }
    
    @Bean
    public CommandLineRunner databaseConnectedMessage(DataSource dataSource) {
        return args -> {
            // Si llegamos a este punto, significa que la base de datos está conectada
            System.out.println("\n====================================");
            System.out.println("¡BASE DE DATOS CONECTADA CORRECTAMENTE!");
            System.out.println("URL: " + dataSource.getConnection().getMetaData().getURL());
            System.out.println("====================================\n");
        };
    }
}
