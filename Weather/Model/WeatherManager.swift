//
//  WeatherManager.swift
//  Clima
//
//  Created by Luka Bukuri on 16.02.21.
//  Copyright © 2021 App. All rights reserved.
//

import Foundation
import CoreLocation

protocol weatherManagerDelegate
{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager
{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=77c83904f41a7cb6e26fdfdf302b0534&units=metric"
    
    var delegate: weatherManagerDelegate?
    
    func fetchWeather(cityName: String)
    {
        let urlString = "\(weatherURL)&q=\(cityName)"
        perfomRequest(with: urlString)
    }
    func fetchWeather(latidute: CLLocationDegrees, longitude: CLLocationDegrees)
    {
        let urlString = "\(weatherURL)&lon=\(longitude)&lat=\(latidute)"
        perfomRequest(with: urlString)
    }
    
    func perfomRequest(with urlString: String)
    {
        //1. Create a URL
        
       if let url = URL(string: urlString)
         {
            //2. Create a URLSession
        
        let session = URLSession(configuration: .default)
        
        //3. Give the Session a task
        
        let task = session.dataTask(with: url) { (data, response, error) in
            print(urlString)
            if error != nil
            {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            
            if let safeData = data
            {
               if let weather = self.parseJSON(safeData)
               {
                self.delegate?.didUpdateWeather(self, weather: weather)
               }
            }
        }
            
        //4. Start the task
        
        task.resume()
         }

    }

    func parseJSON(_ weatherData: Data) -> WeatherModel?
    {
        let decoder = JSONDecoder()
        do{
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        }
        catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
    
}
