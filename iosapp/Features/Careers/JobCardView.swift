import SwiftUI

struct JobCardView: View {
    let job: JobOffer

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title)
                .font(.headline)

            Text(job.department)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(job.location, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(job.shortDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        JobCardView(job: .sample)
    }
    .listStyle(.insetGrouped)
}
