#include <ilopl/iloopl.h>
#include <vector>

using namespace std;

int main() {
  IloEnv env;
  try {
    IloOplErrorHandler handler(env, cout);
    IloOplModelSource model(env, "model.mod");
    IloOplSettings settings(env, handler);
    settings.setWithWarnings(IloFalse);
    IloOplModelDefinition def(model, settings);
    IloCplex cplex(env);
    IloOplModel opl(def, cplex);
    IloOplDataSource data(env, "data.dat");

    opl.addDataSource(data);
    opl.generate();
    if (cplex.solve()) {
      cout << endl <<
        "OBJECTIVE: " << fixed << setprecision(2) << opl.getCplex().getObjValue() <<
        endl;
      opl.postProcess();
      opl.printSolution(cout);
      cplex.writeSolution("solution.sol");
    } else {
      cout << "No solution!" << endl;
      return 404;
    }
  } catch (exception e) {
    cout << "ERROR" << endl;
    return 500;
  }
  return 0;
}
