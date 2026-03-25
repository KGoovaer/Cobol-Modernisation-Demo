package be.betfin.MYFIN.payment;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, UUID> {

    Optional<PaymentRecord> findByPaymentRequestId(UUID paymentRequestId);

    @Query("""
        SELECT r FROM PaymentRecord r
        WHERE (:accountingType IS NULL OR r.accountingType = :accountingType)
          AND (:dateFrom IS NULL OR r.createdAt >= :dateFrom)
          AND (:dateTo IS NULL OR r.createdAt <= :dateTo)
          AND (:mutualities IS NULL OR r.destinationMutuality IN :mutualities)
        ORDER BY r.createdAt DESC
        """)
    Page<PaymentRecord> findFiltered(
        @Param("accountingType") Integer accountingType,
        @Param("dateFrom") Instant dateFrom,
        @Param("dateTo") Instant dateTo,
        @Param("mutualities") Set<Integer> mutualities,
        Pageable pageable
    );

    @Query("""
        SELECT r FROM PaymentRecord r
        WHERE (:mutualities IS NULL OR r.destinationMutuality IN :mutualities)
          AND r.accountingType = 1
        ORDER BY r.createdAt DESC
        """)
    List<PaymentRecord> findStandardForExport(@Param("mutualities") Set<Integer> mutualities);

    Optional<PaymentRecord> findByPaymentRequestConstantId(String constantId);

    Optional<PaymentRecord> findByPaymentRequestSequenceNo(String sequenceNo);
}
