//
//  ViewController.swift
//  ProyectoNotasCoreData
//
//  Created by user on 13/4/21.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var tabla: UITableView!
    
    var categorias = [Categorias]()
    var fetchResultController : NSFetchedResultsController<Categorias>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mostrarCategorias()
    }
    
    //funcion para saber las filas que tiene la tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }
    //funcion para indexar la celda del tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabla.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let categoria = categorias[indexPath.row]
        cell.textLabel?.text = categoria.nombre
        
        return cell
    }
    //Con esto enviamos nuestos datos desde el view controller hacia el tableViewController que hemos creado
//-------------------------------------DESDE AQUI---------------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "notas", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notas"{
            if let id = tabla.indexPathForSelectedRow{
                let fila = categorias[id.row]
                let destino = segue.destination as! NotasTableViewController
                destino.categoriaNotas = fila
            }
            
        }
    }
//------------------------------------HASTA AQUI---------------------------------------------
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let eliminar = UITableViewRowAction(style: .destructive, title: "Eliminar") { (_, indexPath) in
            print("Eliminar")
            let contexto = Conexion().contexto()
            let borrar = self.fetchResultController.object(at: indexPath)
            contexto.delete(borrar)
            do{
                try contexto.save()
            }catch let error as NSError{
                print("Error al borrar", error.localizedDescription)
                
            }
        }
        return [eliminar]
     }
    //MARK: GUARDAR EN ALERTA
    
    @IBAction func guardar(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Nueva Categoria", message: "Ingresa un nombre para la categoria", preferredStyle: .alert)
        alerta.addTextField { (nombre) in
            nombre.placeholder = "Nombre de categoria"
        }
        let aceptar = UIAlertAction(title: "Aceptar", style: .default) { (action) in
            guard let nombre = alerta.textFields?.first?.text else { return }
            let contexto = Conexion().contexto()
            
            let entityCategorias = NSEntityDescription.insertNewObject(forEntityName: "Categorias", into: contexto) as! Categorias
            
            entityCategorias.id = UUID()
            entityCategorias.nombre = nombre
            
            do{
                try contexto.save()
                print("Se guardó")
            }catch let error as NSError{
                print("Hubo un error al guardar", error.localizedDescription)
            }
        }
        let cancelar = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alerta.addAction(aceptar)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true, completion: nil)
    }
    
    //MARK: FETCHRESULTCONTROLLER
    
    func mostrarCategorias(){
        let contexto = Conexion().contexto()
        let fetchRequest : NSFetchRequest<Categorias> = Categorias.fetchRequest()
        
        let orderByNombre = NSSortDescriptor(key: "nombre", ascending: true)
        fetchRequest.sortDescriptors = [orderByNombre]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            categorias = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print("Hubo un error al mostrar datos", error.localizedDescription)
        }
    }
//Este codigo siempre va a ser igual en todos los proyectos solo cambiar tablas o si tenemos sortDescriptors...
//----------------------------------------------DESDE AQUI------------------------------------------------------------
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tabla.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tabla.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tabla.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.tabla.reloadData()
        }
        //Cambiar la tabla Categorias por la tabla que necesitemos
        self.categorias = controller.fetchedObjects as! [Categorias]
    }
//------------------------------------------------HASTA AQUI-------------------------------------
 
}

