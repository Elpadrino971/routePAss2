import SwiftUI

struct AutonomousAccessView: View {
    let booking: RentalBooking
    let onEndRental: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        SmartAccessCardView(
            booking: booking,
            onEndRental: onEndRental,
            onDismiss: onDismiss
        )
    }
}
