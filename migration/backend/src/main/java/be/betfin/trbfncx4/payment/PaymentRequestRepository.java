package be.betfin.MYFIN.payment;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public interface PaymentRequestRepository extends JpaRepository<PaymentRequest, UUID> {

    Optional<PaymentRequest> findByConstantId(String constantId);

    @Query("""
        SELECT pr FROM PaymentRequest pr
        WHERE (:accountingType IS NULL OR pr.accountingType = :accountingType)
          AND (:dateFrom IS NULL OR pr.submittedAt >= :dateFrom)
          AND (:dateTo IS NULL OR pr.submittedAt <= :dateTo)
          AND (:mutualities IS NULL OR pr.destinationMutuality IN :mutualities)
        ORDER BY pr.submittedAt DESC
        """)
    Page<PaymentRequest> findFiltered(
        @Param("accountingType") Integer accountingType,
        @Param("dateFrom") Instant dateFrom,
        @Param("dateTo") Instant dateTo,
        @Param("mutualities") Set<Integer> mutualities,
        Pageable pageable
    );
}
