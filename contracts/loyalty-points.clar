;; Loyalty Points System Contract

;; Define token
(define-fungible-token loyalty-points)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-points (err u101))
(define-constant err-not-authorized (err u102))

;; Data vars
(define-data-var authorized-retailers (list 100 principal) (list))

;; Authorization functions
(define-public (add-retailer (retailer principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set authorized-retailers (unwrap! (as-max-len? (append (var-get authorized-retailers) retailer) u100) err-not-authorized))
        (ok true)
    )
)

;; Check if principal is authorized retailer
(define-private (is-authorized (retailer principal))
    (is-some (index-of (var-get authorized-retailers) retailer))
)

;; Award points to customer
(define-public (award-points (customer principal) (points uint))
    (begin
        (asserts! (is-authorized tx-sender) err-not-authorized)
        (ft-mint? loyalty-points points customer)
    )
)

;; Customer redeem points
(define-public (redeem-points (points uint))
    (let (
        (sender-balance (ft-get-balance loyalty-points tx-sender))
    )
    (if (>= sender-balance points)
        (begin
            (try! (ft-burn? loyalty-points points tx-sender))
            (ok true)
        )
        err-insufficient-points
    ))
)

;; Transfer points between customers
(define-public (transfer-points (amount uint) (recipient principal))
    (let (
        (sender-balance (ft-get-balance loyalty-points tx-sender))
    )
    (if (>= sender-balance amount)
        (begin
            (try! (ft-transfer? loyalty-points amount tx-sender recipient))
            (ok true)
        )
        err-insufficient-points
    ))
)

;; Read only functions
(define-read-only (get-points-balance (customer principal))
    (ok (ft-get-balance loyalty-points customer))
)

(define-read-only (get-authorized-retailers)
    (ok (var-get authorized-retailers))
)
