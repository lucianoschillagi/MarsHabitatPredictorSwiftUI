
import SwiftUI
import CoreML

struct MarsHabitatPredictionApp: View {
    
    // MARK: - Properties
    // Integrating the CoreML Model in the View
    @State private var model : MarsHabitatPricer? = nil
    
    // Static Data (Picker Data Sources)
    let solarPanelsDataSource: [Double] = [1, 1.5, 2, 2.5, 3]
    let greenhousesDataSource: [Double] = [1, 2, 3, 4, 5]
    let acresDataSource: [Double] = [750, 1000, 1500, 2000, 3000, 4000, 5000, 10_000]
    
    // Dynamic Data
    @State private var selectedSolarPanelVal: Double = 2.5 // initial value
    @State private var selectedGreenhouseVal: Double = 3 // initial value
    @State private var selectedAcresVal: Double = 1500 // initial value

    @State private var priceLabel = ""
    
    // MARK: - Presentation
    var body: some View {
        ZStack {
            Image("mars_photo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                Text("Mars Habitat Price Predictor")
                    .font(.largeTitle).bold().fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .padding(.top, 38)
                    .foregroundColor(.black)
                Spacer()
                HStack(alignment: .bottom) {
                    VStack {
                        Text("Solar Panel").font(.title3).underline()
                        Picker("Solar Panel", selection: $selectedSolarPanelVal) {
                            ForEach(solarPanelsDataSource, id: \.self) { value in
                                Text(String(format: "%.1f", value))
                            }
                        }.pickerStyle(.wheel)
                    }
                    VStack {
                        Text("Greenhouse").font(.title3).underline()
                        Picker("Greenhouse", selection: $selectedGreenhouseVal) {
                            ForEach(greenhousesDataSource, id: \.self) { greenhousesDataSource in
                                Text(String(format: "%.0f", greenhousesDataSource))
                            }
                        }.pickerStyle(.wheel)
                    }
                    VStack {
                        Text("Acres").font(.title3).underline()
                        Picker("Acres", selection: $selectedAcresVal) {
                            ForEach(acresDataSource, id: \.self) { acresDataSource in
                                Text(String(format: "%.0f", acresDataSource))
                            }
                        }.pickerStyle(.wheel)
                    }
                }
                .foregroundStyle(.black)
                .padding()
                .background(.ultraThinMaterial)
                .bold()
                .fontDesign(.rounded)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                
                Spacer()
                
                VStack {
                    Text("Predicted Price (millions)")
                        .font(.title)
                    Divider()
                    Text(priceLabel)
                        .font(.largeTitle)
                }
                .foregroundStyle(.thinMaterial)
                .bold()
                .fontDesign(.rounded)
    
                Spacer()
                
            }.padding().foregroundStyle(.white)
        }
        .onAppear {
            loadMLModel()
            initialPickerConfig()
        }
        
        .onChange(of: selectedSolarPanelVal) { oldState, newState in
            print("Solar Panel new value \(newState)")
            marsHabitatPricerOutput(solarInputValue: newState, greenhouseInputValue: selectedGreenhouseVal, acreInputValue: selectedAcresVal)
        }
        
        .onChange(of: selectedGreenhouseVal) { oldState, newState in
            print("Greenhouse new value  \(newState)")
            marsHabitatPricerOutput(solarInputValue: selectedSolarPanelVal, greenhouseInputValue: newState, acreInputValue: selectedAcresVal)
        }
        
        .onChange(of: selectedAcresVal) { oldState, newState in
            print("Acres new value  \(newState)")
            marsHabitatPricerOutput(solarInputValue: selectedSolarPanelVal, greenhouseInputValue: selectedGreenhouseVal, acreInputValue: newState)
        }
        
    }
    
    // MARK: - Logic
    func loadMLModel() {
        do {
            let config = MLModelConfiguration()
            self.model = try MarsHabitatPricer(configuration: config)
        } catch {
            fatalError("Unexpected runtime error.")
        }
    }
    
    func initialPickerConfig() {
        guard let marsHabitatPricerOutput = try? model?.prediction(solarPanels: selectedSolarPanelVal, greenhouses: selectedGreenhouseVal , size: selectedAcresVal) else {
            fatalError("Unexpected runtime error.")
        }
        let price = marsHabitatPricerOutput.price
        priceLabel = priceFormatter.string(for: price) ?? ""
    }
    
    func marsHabitatPricerOutput(solarInputValue: Double, greenhouseInputValue: Double, acreInputValue: Double) {
      
        // Main Logic - The Prediction - The Output (MarsHabitatPricerOutput)
        guard let marsHabitatPricerOutput = try? model?.prediction(solarPanels: solarInputValue, greenhouses: greenhouseInputValue, size: acreInputValue) else {
            fatalError("Unexpected runtime error.")
        }
        let price = marsHabitatPricerOutput.price
        priceLabel = priceFormatter.string(for: price) ?? ""
    
    }
    
    // MARK: - Helpers
    /// Formatter for the output.
    let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
}

#Preview {
    MarsHabitatPredictionApp()
}
