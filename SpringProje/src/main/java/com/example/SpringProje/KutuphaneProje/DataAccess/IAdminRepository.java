package com.example.SpringProje.KutuphaneProje.DataAccess;

import com.example.SpringProje.KutuphaneProje.Entities.Admin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IAdminRepository extends JpaRepository<Admin,Integer> {

    Optional<Admin> findByEmail(String email);

    boolean existsByEmail(String email);

}
