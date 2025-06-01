package com.gestorhorarios.config;

import org.flywaydb.core.Flyway;
import javax.sql.DataSource;

// Flyway temporalmente deshabilitado
// @Configuration
// @Profile("!test") // Don't run this in tests
public class FlywayConfig {
    
    // @Bean
    public Flyway flyway(DataSource dataSource) {
        // Flyway deshabilitado temporalmente
        return null;
        /*
        // First configure Flyway with clean disabled
        Flyway flyway = Flyway.configure()
            .dataSource(dataSource)
            .baselineOnMigrate(true)
            .outOfOrder(true)
            .validateOnMigrate(false)
            .cleanDisabled(true) // Keep clean disabled
            .load();
            
        // Run migrations
        flyway.migrate();
        
        return flyway;
        */
    }
}
