import SwiftUI

struct ContentView: View {
    @State private var city: String = ""
    @State private var weatherInfo: String = "Enter a city to get weather"
    @State private var weatherIconURL: String = ""

    var body: some View {
        VStack {
            Text("Weather App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Enter City", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                fetchWeather(for: city)
            }) {
                Text("Get Weather")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            if !weatherIconURL.isEmpty {
                AsyncImage(url: URL(string: weatherIconURL)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                }
            }

            Text(weatherInfo)
                .padding()
                .multilineTextAlignment(.center)
                .font(.title2)
        }
        .padding()
    }

    func fetchWeather(for city: String) {
        let apiKey = "dc1998da1e00ff0c46b3370de48470fe"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            weatherInfo = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    weatherInfo = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    weatherInfo = "No data received"
                }
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                if let weather = decodedData.weather.first {
                    let iconURL = "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"
                    DispatchQueue.main.async {
                        weatherInfo = "🌡 Temperature: \(decodedData.main.temp)°C\n🌤 \(weather.description.capitalized)"
                        weatherIconURL = iconURL
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    weatherInfo = "Failed to decode weather data"
                }
            }
        }.resume()
    }
}

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

