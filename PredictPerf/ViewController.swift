//
//  ViewController.swift
//  PredictPerf
//
//  Created by Arthur Péligry on 06/03/2018.
//  Copyright © 2018 Arthur Péligry. All rights reserved.
//

import UIKit
import MapKit
import McPicker
import Firebase
import FirebaseDatabase
import ChameleonFramework
import Pastel
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import PinFloyd
import Spring
import FlyoverKit
import FloatRatingView
import SwiftIcons

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    // Base de données
    var ref: DatabaseReference?

    // Location Manager
    var locationManager = CLLocationManager()
    
    let clusteringManager = ClusteringManager()
    
    var annotations: [MKPointAnnotation] = []
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    
    @IBOutlet weak var mapView: RoundShadowView!
    @IBOutlet weak var planView: MKMapView!
    @IBOutlet weak var resultsView: UITableView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var containerView: SpringView!
    @IBOutlet weak var detailView: RoundShadowView!
    
    @IBOutlet weak var titreDetail: UILabel!
    @IBOutlet weak var domaineDetail: UILabel!
    @IBOutlet weak var noteDetailAnneeN: UILabel!
    @IBOutlet weak var noteDetailAnneeN1: UILabel!
    @IBOutlet weak var ratingDetailAnneeN: FloatRatingView!
    @IBOutlet weak var ratingDetailAnneeN1: FloatRatingView!
    
    @IBOutlet weak var variationNote: UILabel!
    @IBOutlet weak var variationIcon: UIImageView!
    
    @IBOutlet weak var chiffreAffaire: UILabel!
    @IBOutlet weak var ratioEBECA: UILabel!
    @IBOutlet weak var rentabiliteCxEngages: UILabel!
    @IBOutlet weak var rentabiliteFi: UILabel!
    
    @IBOutlet weak var activityWindow: RoundShadowView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    
    
    @IBOutlet weak var planDetailView: MKMapView!
    
    
    
    @IBAction func test(_ sender: Any) {
        
        // let flyoverCamera = FlyoverCamera(mapView: self.detailPlanView, configurationTheme: .default)
        
        
    }
    

    @IBAction func detailClose(_ sender: Any) {
        
        blurView.isHidden = true
        // detailPlanView.stop()
        // let flyoverCamera = FlyoverCamera(mapView: self.detailPlanView, configurationTheme: .default)
        // flyoverCamera.stop()
    }

    
    @IBAction func helper(_ sender: Any) {
        
        looping()

    }
    
    @IBAction func helper2(_ sender: Any) {
        
        var i = 0
        
        for element in LocalData.Data.data {
            uploadFirebase(i: i)
            i += 1
        }
        
    }
    
    
    func looping() {
        
        var i = 0
            
        for element in LocalData.Data.data {
            
            if element["Geolocalisation"] is Int {
                var adresse = ""
                var cp = 0
                var ville = ""
                
                if element["Adresse"]! is String {
                    adresse = element["Adresse"]! as! String
                } else {
                    adresse = ""
                }
                
                if element["CodePostal"]! is Int {
                    cp = element["CodePostal"]! as! Int
                } else {
                    cp = 0
                }
                
                if element["Ville"]! is String {
                    ville = element["Ville"]! as! String
                } else {
                    ville = ""
                }
                
                sendGeocodingApiRequest(adresse: adresse, cp: cp, city: ville, index: i)
                
            } else {
                
                let geo = element["Geolocalisation"] as! String
                
                let null = "null,null"
                
                if geo == null {
                    var adresse = ""
                    var cp = 0
                    var ville = ""
                    
                    if element["Adresse"]! is String {
                        adresse = element["Adresse"]! as! String
                    } else {
                        adresse = ""
                    }
                    
                    if element["CodePostal"]! is Int {
                        cp = element["CodePostal"]! as! Int
                    } else {
                        cp = 0
                    }
                    
                    if element["Ville"]! is String {
                        ville = element["Ville"]! as! String
                    } else {
                        ville = ""
                    }
                    
                    sendGeocodingApiRequest(adresse: adresse, cp: cp, city: ville, index: i)
                }
            }
            
            i += 1
            
            
        }
        
    }
    
    func sendGeocodingApiRequest(adresse: String, cp: Int, city: String, index: Int) {
       
        let adresseGeocode = adresse.replacingOccurrences(of: " ", with: "+")
        let cityGeocode = city.replacingOccurrences(of: " ", with: "+")
        
        // Add URL parameters
        let urlParams = [
            "address":"\(adresseGeocode),+\(cp),+\(cityGeocode)",
            "key":"AIzaSyCT95RXtxAxV_24olVASwb6UBORjaj_xXM",
            ]
        
        // Fetch Request
        Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let swiftyJsonVar = JSON(response.result.value!)
                    let lat = swiftyJsonVar["results"][0]["geometry"]["location"]["lat"]
                    let long = swiftyJsonVar["results"][0]["geometry"]["location"]["lng"]
                    let coordinates = "\(lat),\(long)"
                    print(coordinates)
                    LocalData.Data.data[index]["Geolocalisation"] = coordinates
                    
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    func uploadFirebase(i: Int) {
        
        let index = i + 1
        
        let geoloc = LocalData.Data.data[i]["Geolocalisation"]
        let adresse = LocalData.Data.data[i]["Adresse"]
        let bfr = LocalData.Data.data[i]["BFR"]
        let ca = LocalData.Data.data[i]["CA"]
        let codeAPE = LocalData.Data.data[i]["CodeAPE"]
        let codeGreffe = LocalData.Data.data[i]["CodeGreffe"]
        let codePostal = LocalData.Data.data[i]["CodePostal"]
        let dateImmatriculation = LocalData.Data.data[i]["DateImmatriculation"]
        let dateRadiation = LocalData.Data.data[i]["DateRadiation"]
        let denomination = LocalData.Data.data[i]["Denomination"]
        let departement = LocalData.Data.data[i]["Departement"]
        let formeJuridique = LocalData.Data.data[i]["FormeJuridique"]
        let greffe = LocalData.Data.data[i]["Greffe"]
        let libelleAPE = LocalData.Data.data[i]["LibelleAPE"]
        let nic = LocalData.Data.data[i]["Nic"]
        let note2016 = LocalData.Data.data[i]["Note2016"]
        let numDept = LocalData.Data.data[i]["NumDept"]
        let pred2017 = LocalData.Data.data[i]["Pred2017"]
        let ratioEBECA = LocalData.Data.data[i]["RationEBECA"]
        let region = LocalData.Data.data[i]["Region"]
        let rentabiliteEco = LocalData.Data.data[i]["RentabiliteEconomique"]
        let retabiliteFinanciere = LocalData.Data.data[i]["RentabiliteFinanciere"]
        let siren = LocalData.Data.data[i]["Siren"]
        let statut = LocalData.Data.data[i]["Statut"]
        let ville = LocalData.Data.data[i]["Ville"]
    
        let postDestination = [
            "Geolocalisation": geoloc,
            "Adresse": adresse,
            "BFR": bfr,
            "CA": ca,
            "CodeAPE": codeAPE,
            "CodeGreffe": codeGreffe,
            "CodePostal": codePostal,
            "DateImmatriculation" : dateImmatriculation,
            "DateRadiation" : dateRadiation,
            "Denomination" : denomination,
            "Departement" : departement,
            "FormeJuridique" : formeJuridique,
            "Greffe" : greffe,
            "LibelleAPE" : libelleAPE,
            "Nic" : nic,
            "Note2016" : note2016,
            "NumDept" : numDept,
            "Pred2017" : pred2017,
            "RationEBECA" : ratioEBECA,
            "Region" : region,
            "RentabiliteEconomique" : rentabiliteEco,
            "RentabiliteFinanciere" : retabiliteFinanciere,
            "Siren" : siren,
            "Statut" : statut,
            "Ville" : ville
            ] as [String : Any]
        let childUpdatesDestination = ["data/\(index)": postDestination]
        ref?.updateChildValues(childUpdatesDestination)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientBackground(viewName: view)
        
        ref = Database.database().reference()
        loadData()
    
        
        setMap(latitude: 46.7906888, longitude: 1.6367961, deltaLat: 12, deltaLong: 12)
        startLocationServices()
        moveMap()
        
        setView()
        
        // planDetailView = FlyoverMapView()
    }
    
    func setView() {
        
        blurView.isHidden = true
        containerView.isHidden = true
        
        activityIndicator.startAnimating()
        resultsView.isHidden = true
        resultsView.rowHeight = 100
        mapView.isHidden = true
        label1.isHidden = true
        label2.isHidden = true
        arrow.isHidden = true
        
        
    }
    
    func loadData() {
        
        ref?.child("data").queryOrdered(byChild: "Note2016").observe(.value) {
            (snapshot: DataSnapshot) in
            
            if ( snapshot.value is NSNull ) {
                // self.noInternetConnection()
            } else {
                
                LocalData.Data.data.removeAll()
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot //each child is a snapshot
                    let dict = snap.value as! [String: Any] // the value is a dict
                    LocalData.Data.data.append(dict)
                }
                
                self.activityWindow.isHidden = true
                self.activityIndicator.stopAnimating()
                
                self.mapView.isHidden = false
                self.label1.isHidden = false
                self.label2.isHidden = false
                self.arrow.isHidden = false
                
                // self.loadAnnotations(option: "all")
            }
        }
        
    }
    
    func startLocationServices() {
        
        //Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
        
        DispatchQueue.main.async {
            
            // Location
            self.planView.delegate = self
            self.planView.showsUserLocation = true
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            
        }
    }
    
    func setMap(latitude: Double, longitude: Double, deltaLat: Double, deltaLong: Double) {
        
        let momentaryLatitude = latitude
        let momentaryLongitude = longitude
        
        let latitude:CLLocationDegrees = momentaryLatitude
        let long:CLLocationDegrees = momentaryLongitude
        let latDelta:CLLocationDegrees = deltaLat
        let longDelta:CLLocationDegrees = deltaLong
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: long)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        
        self.planView.setRegion(region, animated: true)
        self.planView.mapType = MKMapType.hybrid
    }
    
    func setMapDetail(latitude: Double, longitude: Double, deltaLat: Double, deltaLong: Double) {
        
        let momentaryLatitude = latitude
        let momentaryLongitude = longitude
        
        let latitude:CLLocationDegrees = momentaryLatitude
        let long:CLLocationDegrees = momentaryLongitude
        let latDelta:CLLocationDegrees = deltaLat
        let longDelta:CLLocationDegrees = deltaLong
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: long)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        

        self.planDetailView.setRegion(region, animated: true)
        self.planDetailView.mapType = MKMapType.hybrid
    }
    
    
    func moveMap() {
        // déplacement de la map
        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        // make your class the delegate of the pan gesture
        panGesture.delegate = self
        // add the gesture to the mapView
        planView.addGestureRecognizer(panGesture)
    }
    
    func createAnnotation(i: Int, option: String) {

        var dict = String()
        
        if option == "all" {
             dict = LocalData.Data.data[i]["Geolocalisation"] as! String
        }
        if option == "selected" {
            dict = LocalData.Data.Selected.data[i]["Geolocalisation"] as! String
        }
        
        
        
        let delimiter = ","
        let token = dict.components(separatedBy: delimiter)
        let lat = Double(token[0])
        let long = Double(token[1])
        
        let annotation = MKPointAnnotation()
        // let annotation = Annotation()
        
        // annotation.title =  LocalData.Data.Selected.data[i]["Denomination"] as? String
        
        // let rentabiliteFinanciere = LocalData.Data.Selected.data[i]["Note2016"]
        // annotation.subtitle = "Note 2016 : \(String(describing: rentabiliteFinanciere))"
        
        let latitude = lat
        let longitude = long
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        annotation.coordinate = location
        
        annotations.append(annotation)
        //self.planView.addAnnotation(annotation)
        
    }
    
    func loadAnnotations(option: String) {
        
        annotations.removeAll()
        clusteringManager.removeAll()
        
        var i = 0
        
        if option == "selected" {
            while i < LocalData.Data.Selected.data.count {
                createAnnotation(i: i, option: "selected")
                i += 1
            }
        }
        if option == "all" {
            while i < LocalData.Data.data.count {
                createAnnotation(i: i, option: "all")
                i += 1
            }
        }
        clusteringManager.add(annotations: annotations)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let annotation as ClusterAnnotation:
            let id = ClusterAnnotationView.identifier
            
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if clusterView == nil {
                clusterView = ClusterAnnotationView(annotation: annotation, reuseIdentifier: id)
            } else {
                clusterView?.annotation = annotation
            }
            
            return clusterView
        default:
            
            if mapView == self.planView {
                
                let reuseID = "pin"
                
                var view: MKPinAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
                    as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                } else {
                    // 3
                    view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                    view.canShowCallout = true
                    view.isUserInteractionEnabled = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    view.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as UIButton
                }
                return view
                
            }
            
            return nil
            
        }
    }
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if mapView == self.planView {
            
            let reuseID = "pin"
            
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                view.canShowCallout = true
                view.isUserInteractionEnabled = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as UIButton
            }
            return view
            
        }
        
        return nil
       
    } */
 
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if mapView == self.planView {
            if control == view.rightCalloutAccessoryView {
                
                print("Yolo")
                
            }
        }
        
    }
    
    
    // TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocalData.Data.Selected.data.count
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let dict = LocalData.Data.Selected.data[indexPath.row]["Geolocalisation"] as! String
        let delimiter = ","
        let token = dict.components(separatedBy: delimiter)
        let lat = Double(token[0])
        let long = Double(token[1])
        
        setMapDetail(latitude: lat!, longitude: long!, deltaLat: 0.001, deltaLong: 0.001)
        
        let noteAnneeN = LocalData.Data.Selected.data[indexPath.row]["Note2016"]! as! Double
        let noteAnneeN1 = LocalData.Data.Selected.data[indexPath.row]["Pred2017"]! as! Double
        let rounded = String(format: "%.2f", noteAnneeN1)
        let roundedDouble = Double(rounded)
        let rating = noteAnneeN/20*5
        let rating2 = roundedDouble!/20*5
        ratingDetailAnneeN.rating = rating
        ratingDetailAnneeN1.rating = rating2
        noteDetailAnneeN.text = "\(noteAnneeN)/20"
        noteDetailAnneeN1.text = "\(roundedDouble!)/20"
        
        let ca = LocalData.Data.Selected.data[indexPath.row]["CA"]! as! Double
        let EBECA = LocalData.Data.Selected.data[indexPath.row]["RationEBECA"]! as! Double
        let rentaEco = LocalData.Data.Selected.data[indexPath.row]["RentabiliteEconomique"]! as! Double
        let rentaFi = LocalData.Data.Selected.data[indexPath.row]["RentabiliteFinanciere"]! as! Double
        
        chiffreAffaire.text = String(describing: ca)
        ratioEBECA.text = String(describing: EBECA)
        rentabiliteCxEngages.text = String(describing: rentaEco)
        rentabiliteFi.text = String(describing: rentaFi)
        
        let variation = (roundedDouble! - noteAnneeN) / noteAnneeN * 100
        let roundedVariation = String(format: "%.2f", variation)
        let roundedVariationDouble = Double(roundedVariation)
        variationNote.text = "\(roundedVariationDouble!) %"
        
        if variation > 0 {
            variationIcon.setIcon(icon: .googleMaterialDesign(.trendingUp), textColor: .green)
            variationNote.textColor = .green
        }
        if variation < 0 {
            variationIcon.setIcon(icon: .googleMaterialDesign(.trendingDown), textColor: .red)
            variationNote.textColor = .red
        }
        if variation == 0 {
            variationIcon.setIcon(icon: .googleMaterialDesign(.trendingFlat), textColor: .orange)
            variationNote.textColor = .orange
        }
        // valeur arrivée - valeur de départ / valeur de départ * 100
        
        
        
        titreDetail.text = LocalData.Data.Selected.data[indexPath.row]["Denomination"]! as? String
        domaineDetail.text = LocalData.Data.Selected.data[indexPath.row]["LibelleAPE"] as? String
        
        blurView.isHidden = false
        Animations.pop(viewGiven: containerView)
    }
    
    func loadFlyover(lat: Double, long: Double) {
        let flyoverCamera = FlyoverCamera(mapView: self.planDetailView)
        
        // Initialize a location via CLLocationCoordinate2D
        let eiffelTower = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        // Start flyover
        flyoverCamera.start(flyover: eiffelTower)
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "domaineCell", for: indexPath) as! domaineCell
        
        cell.selectionStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none // OK
        
        let row = indexPath.row + 1
        if row == 1 {
            cell.medal.backgroundColor = HexColor("D49939")
            cell.rank.textColor = UIColor.white
        } else if row == 2 {
            cell.medal.backgroundColor = HexColor("C5BABA")
        } else if row == 3 {
            cell.medal.backgroundColor = HexColor("8B4F31")
            cell.rank.textColor = UIColor.white
        } else {
            cell.medal.backgroundColor = UIColor.clear
        }
        
        
        cell.rank.text = String(row)
        cell.firmName.text = LocalData.Data.Selected.data[indexPath.row]["Denomination"] as? String
        cell.libelleAPE.text = LocalData.Data.Selected.data[indexPath.row]["LibelleAPE"] as? String
        
        let chiffre = LocalData.Data.Selected.data[indexPath.row]["Note2016"]! as! Double
        let rating = chiffre/20*5
        cell.ratingView.rating = rating
        cell.noteAFDCC.text = "\(chiffre)/20"
        cell.ville.text = "Ville : \(LocalData.Data.Selected.data[indexPath.row]["Ville"] as! String)"
        return cell
    }
    
    // Déplacement de la map
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            
            let allAnnotations = self.planView.annotations
            self.planView.removeAnnotations(allAnnotations)
            
            self.checkCoordinates()
            
        }
    }
    
    func checkCoordinates() {
        
        LocalData.Data.Selected.data.removeAll()
        
        let radius = CLCircularRegion.init(center: planView.centerCoordinate, radius: planView.currentRadius(), identifier: "test")
        
        var i = 0
        
        for element in LocalData.Data.data {
            
            var dict = String()
            
            if LocalData.Data.data[i]["Geolocalisation"] is String {
                
                dict = LocalData.Data.data[i]["Geolocalisation"] as! String
                if dict != "null,null" {
                    let delimiter = ","
                    let token = dict.components(separatedBy: delimiter)
                    let lat = Double(token[0])
                    let long = Double(token[1])
                    
                    let latitude = lat
                    let longitude = long
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    
                    if radius.contains(location) == true {
                        LocalData.Data.Selected.data.append(element)
                    }
                }
                
            } else {
                
                print("no geo info found")
                
            }
            
            i += 1
            
        }
        
        LocalData.Data.Selected.data.reverse()
        self.resultsView.reloadData()
        self.resultsView.isHidden = false
        self.arrow.isHidden = true
        self.label1.isHidden = true
        Animations.animateCells(tableView: resultsView)
        
        loadAnnotations(option: "selected")
    
    }
    
    func setGradientBackground(viewName: UIView) {
        
        let pastelView = PastelView(frame: viewName.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 6.0
        
        // Custom Color
        let coolUIColor = [HexColor("f7f3e3"), HexColor("ecf0f1"), HexColor("BCD8C1")]
        pastelView.setColors(coolUIColor as! [UIColor])
        
        pastelView.startAnimation()
        viewName.insertSubview(pastelView, at: 0)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusteringManager.renderAnnotations(onMapView: mapView)
    }
    
}

// Déplacement de la map
extension MKMapView {
    
    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        print(center.latitude)
        print(center.longitude)
    }
    

    
    func currentRadius() -> Double {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
    }
    
}
