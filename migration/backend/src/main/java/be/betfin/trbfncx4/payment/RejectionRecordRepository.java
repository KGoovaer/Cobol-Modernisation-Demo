package be.betfin.MYFIN.payment;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

public interface RejectionRecordRepository extends JpaRepository<RejectionRecord, UUID> {

    @Query("""
        SELECT r FROM RejectionRecord r
        JOIN r.paymentRequest pr
        WHERE (:accountingType IS NULL OR pr.accountingType = :accountingType)
          AND (:dateFrom IS NULL OR r.createdAt >= :dateFrom)
          AND (:dateTo IS NULL OR r.createdAt <= :dateTo)
          AND (:mutualities IS NULL OR pr.destinationMutuality IN :mutualities)
        ORDER BY r.createdAt DESC
        """)
    Page<RejectionRecord> findFiltered(
        @Param("accountingType") Integer accountingType,
        @Param("dateFrom") Instant dateFrom,
        @Param("dateTo") Instant dateTo,
        @Param("mutualities") Set<Integer> mutualities,
        Pageable pageable
    );
}
