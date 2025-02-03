;; Loyalty Points System Contract

;; Define token
(define-fungible-token loyalty-points)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-points (err u101))
(define-constant err-not-authorized (err u102)) 
(define-constant err-invalid-tier (err u103))

;; Data vars
(define-data-var authorized-retailers (list 100 principal) (list))
(define-map reward-tiers uint {
  name: (string-ascii 20),
  points-required: uint,
  multiplier: uint
})

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

;; Configure reward tiers
(define-public (set-reward-tier (tier-id uint) (name (string-ascii 20)) (points-required uint) (multiplier uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set reward-tiers tier-id {
            name: name,
            points-required: points-required,
            multiplier: multiplier
        })
        (ok true)
    )
)

;; Get customer's highest eligible tier
(define-read-only (get-customer-tier (customer principal))
    (let ((balance (ft-get-balance loyalty-points customer)))
      (get-highest-eligible-tier balance (map-keys reward-tiers))
    )
)

;; Get highest tier customer qualifies for
(define-private (get-highest-eligible-tier (balance uint) (tier-ids (list 100 uint)))
    (let ((highest-tier (fold check-tier-eligibility u0 tier-ids)))
      highest-tier
    )
)

;; Check if customer eligible for tier and return highest tier
(define-private (check-tier-eligibility (tier-id uint) (current-highest uint))
    (match (map-get? reward-tiers tier-id)
      tier-info (if (and
                    (>= (ft-get-balance loyalty-points tx-sender) (get points-required tier-info))
                    (> tier-id current-highest))
                  tier-id
                  current-highest)
      current-highest
    )
)

;; Award points to customer with tier multiplier
(define-public (award-points (customer principal) (base-points uint))
    (let (
        (customer-tier (get-customer-tier customer))
        (tier-info (map-get? reward-tiers customer-tier))
        (tier-multiplier (default-to u1 (get multiplier tier-info)))
        (final-points (* base-points tier-multiplier))
    )
    (begin
        (asserts! (is-authorized tx-sender) err-not-authorized)
        (ft-mint? loyalty-points final-points customer)
    ))
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

(define-read-only (get-tier-info (tier-id uint))
    (ok (map-get? reward-tiers tier-id))
)
