package be.betfin.MYFIN.payment;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Set;
import java.util.UUID;

public interface BankAccountDiscrepancyRepository extends JpaRepository<BankAccountDiscrepancy, UUID> {

    @Query("""
        SELECT d FROM BankAccountDiscrepancy d
        JOIN d.paymentRequest pr
        WHERE (:mutualities IS NULL OR pr.destinationMutuality IN :mutualities)
        ORDER BY d.createdAt DESC
        """)
    Page<BankAccountDiscrepancy> findForUser(
        @Param("mutualities") Set<Integer> mutualities,
        Pageable pageable
    );
}
