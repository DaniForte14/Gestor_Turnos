package com.gestorhorarios.repository;

import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findByUsernameOrEmail(String username, String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    List<User> findByRolesIn(Set<Role> roles);
    List<User> findByRolesContaining(Role role);
}
