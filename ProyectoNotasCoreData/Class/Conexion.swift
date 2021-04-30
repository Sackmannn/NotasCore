//
//  conexion.swift
//  ProyectoNotasCoreData
//
//  Created by user on 14/4/21.
//

import Foundation
import CoreData
import UIKit

class Conexion {
    
    
    func contexto()->NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
}
