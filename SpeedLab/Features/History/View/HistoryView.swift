//
//  HistoryView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 2.02.2026.
//
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationView {
            List{
                ForEach(viewModel.sessions, id: \.self) { session in
                    VStack(alignment: .leading, spacing: 10) {
                        
                        HStack {
                            Text(session.timestamp ?? Date(), style: .date)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(session.timestamp ?? Date(), style: .time)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                      
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                InfoRow(label: "Mesafe", value: String(format: "%.2f km", session.distance))
                                InfoRow(label: "Süre", value: formatDuration(session.duration))
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                InfoRow(label: "Max Hız", value: String(format: "%.0f km/h", session.maxSpeed))
                                InfoRow(label: "Max G", value: String(format: "%.2f G", session.maxGForce))
                            }
                        }
                    
                        if session.zeroToHundred > 0 || session.zeroToTwoHundred > 0 || session.brakingDistance > 0 {
                            Divider()
                            
                            HStack {
                                if session.zeroToHundred > 0 && session.zeroToHundred < 1000 {
                                    PerformanceBadge(title: "0-100", value: String(format: "%.2fs", session.zeroToHundred))
                                }
                                
                                if session.zeroToTwoHundred > 0 && session.zeroToTwoHundred < 1500 {
                                    Spacer()
                                    PerformanceBadge(title: "0-200", value: String(format: "%.2fs", session.zeroToTwoHundred))
                                }
                                
                                if session.brakingDistance > 0 && session.brakingDistance < 500  {
                                    Spacer()
                                    PerformanceBadge(title: "100-0", value: String(format: "%.1f m", session.brakingDistance), color: .red)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                }
                .onDelete(perform: viewModel.deleteSession)
            }
            .navigationTitle("Drive History")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .listRowSpacing(12)
            .padding(.bottom, 32)
        }
    }
    
    
    func formatDuration(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(seconds)) ?? "\(Int(seconds))s"
    }
}


// Standart Bilgi Satırı
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// Performans Değerleri için Renkli Kutu
struct PerformanceBadge: View {
    let title: String
    let value: String
    var color: Color = .green
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    HistoryView()
}
