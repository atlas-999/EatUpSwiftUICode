import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool
    var label: String = ""
    var onColor: Color = .green
    var offColor: Color = .gray
    var knobColor: Color = .white
    
    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(isOn ? onColor : offColor)
                    .frame(width: 50, height: 30)
                    .animation(.easeInOut(duration: 0.2), value: isOn)
                
                Circle()
                    .fill(knobColor)
                    .frame(width: 24, height: 24)
                    .padding(3)
                    .shadow(radius: 1)
                    .animation(.easeInOut(duration: 0.2), value: isOn)
            }
            .onTapGesture {
                withAnimation {
                    isOn.toggle()
                }
            }
        }
        .padding(.horizontal)
    }
}