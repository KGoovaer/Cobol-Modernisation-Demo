package be.betfin.MYFIN.payment;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * T028 – Repository for PaymentDescription lookup table.
 */
public interface PaymentDescriptionRepository extends JpaRepository<PaymentDescription, Integer> {
}
